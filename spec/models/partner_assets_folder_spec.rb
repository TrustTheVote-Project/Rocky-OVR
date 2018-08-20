#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe PartnerAssetsFolder do

  before(:each) do
    allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(FakeS3.new)
    @partner = FactoryGirl.create(:partner)
    @partner.stub(:partner_root).and_return("partners/TEST")
    @paf = PartnerAssetsFolder.new(@partner)
  end

  after  {  @paf.directory.files.each {|f| f.destroy} }

  describe 'update_css' do
    it 'should save asset file' do
      @file = File.new("#{fixture_files_path}/sample.css")
      @paf.update_css('application', @file)
      @partner.application_css_present?.should be_truthy
    end

    context 'updating' do
      before do
        @file = File.new("#{fixture_files_path}/sample.css")
        @alt  = File.new("#{fixture_files_path}/alt.css")
        @paf.update_css('application', @file)
        @paf.update_css('application', @alt)
      end

      it 'should replace asset file' do
        @partner.folder.asset_file(@partner.application_css_path).body.should == "alt\n"
      end

      it 'should create the versioned copy' do
        css_files = @paf.directory.files.select {|f| f.key.starts_with?(@partner.absolute_old_assets_path) }
        css_files.count.should == 1
        css_files.first.key.should match /\/application-#{Time.now.strftime("%Y%m%d%H")}\d{4}\.css$/
      end
    end
  end

  describe 'list_assets' do
    before do
      @file = File.new("#{fixture_files_path}/sample.css")
      @paf.update_css('application', @file)
      @paf.update_css('application', @file)
      @paf.update_asset('bg.png', @file)
    end

    it 'should list assets only' do
      @paf.list_assets.should == [ 'application.css', 'bg.png' ]
    end
  end

  describe 'delete_asset' do
    before do
      @file = File.new("#{fixture_files_path}/sample.css")
      @paf.update_css('application', @file)
      
    end

    it 'should delete asset' do
      @paf.delete_asset('application.css')
      @paf.list_assets.should == []
    end

    it 'should not error on removing unknown asset' do
      @paf.delete_asset('unknown')
      @paf.list_assets.should == [ 'application.css' ]
    end
  end

  describe 'upload_asset' do
    it 'should upload an asset' do
      @file = File.new("#{fixture_files_path}/sample.css")
      @paf.update_asset('sample.css', @file)
      @paf.list_assets.should == [ 'sample.css' ]
    end
  end

  describe 'sub_assets' do
    it 'respect sub directories ' do
      test_file = double(
          public_url: "public_url",
          key: File.join(@partner.assets_path, 'test', 'file.txt'),
          destroy: nil
      )
      directory = double(files: [test_file])
      allow(@paf).to receive(:directory).and_return(directory)

      expect(@paf.asset_url('file.txt', 'test')).to be_eql("public_url")
      expect(@paf.asset_file('file.txt', 'test')).to be_eql(test_file)
    end
  end

  describe 'publish sub assets' do

    it 'copies new files and remove old ones' do
      folder = @partner.assets_path + '/'
      files = [
          double(key: folder + 'asset1.jpg', public_url: 'https://server/asset1.jpg', body: 'b1'),
          double(key: folder + 'asset2.jpg', public_url: 'https://server/asset1.jpg', body: 'b2'),
          double(key: folder + 'test/asset1.jpg', public_url: 'https://server/test/asset1.jpg', body: 'new1'),
          double(key: folder + 'test/asset3.jpg', public_url: 'https://server/test/asset3.jpg', body: 'new3'),
      ]
      directory = double(files: files)
      allow(@partner.folder).to receive(:directory).and_return(directory)
      allow(@partner.folder).to receive(:existing) { |path| files.find { |f| f.key == path } }

      expect(files[1]).to receive(:destroy)
      expect(@partner.folder).to receive(:create_version).with(folder + 'asset1.jpg')
      # current logic doesn't assume version creation on file deletion
      # expect(@partner.folder).to receive(:create_version).with(folder + 'asset2.jpg')

      expect(@partner.folder).to receive(:write_file).with(folder + 'asset1.jpg', 'new1')
      expect(@partner.folder).to receive(:write_file).with(folder + 'asset3.jpg', 'new3')

      @partner.folder.publish_sub_assets(:test)
    end
  end

  describe 'parse_file_key' do
    subject { @paf.parse_file_key(key) }

    context 'root files' do
      let(:key) { [@partner.assets_path, 'example.file'].join('/') }

      it 'has empty folder and proper filename' do
        expect(subject.folder).to be_empty
        expect(subject.basename).to be_eql('example.file')
      end
    end

    context 'sub-folder files' do
      let(:key) { [@partner.assets_path, 'directory', 'example.file'].join('/') }
      it 'has proper folder and file names' do
        expect(subject.folder).to be_eql('directory')
        expect(subject.basename).to be_eql('example.file')
      end
    end

    context 'sub-sub-folder files' do
      let(:key) { [@partner.assets_path, 'directory', 'sub-dir', 'example.file'].join('/') }
      it 'has empty folder and file names' do
        expect(subject.folder).to be_empty
        expect(subject.basename).to be_empty
      end
    end

    context 'other partner files' do
      let(:another_partner) { FactoryGirl.create(:partner) }
      let(:key) { [another_partner.assets_path, 'example.file'].join('/') }
      it 'has empty folder and file names' do
        expect(subject.folder).to be_empty
        expect(subject.basename).to be_empty
      end
    end
  end

  describe 'files_by_folder' do
    before do
      allow_any_instance_of(PartnerAssetsFolder).to receive(:directory).and_return(PartnerFakeS3.wrap(@partner, %w(r1 r2 s/sr1 s/sr2)))
    end

    it 'returns root files' do
      actual_keys = @paf.files_by_folder('').keys
      expected_keys = %w(r1 r2)
      expect(actual_keys).to match_array(expected_keys)
    end

    it 'returns sub-files' do
      actual_keys = @paf.files_by_folder('s').keys
      expected_keys = %w(sr1 sr2)
      expect(actual_keys).to match_array(expected_keys)
    end

    it 'respects empty sub folders' do
      expect(@paf.files_by_folder('x').keys).to be_empty
    end
  end
end
