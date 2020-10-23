class AbrPdfCoverPageMerger
    
    def self.pdf_template_path(home_state_abbrev, pdf_template_name)
        abbrev = home_state_abbrev.downcase
        Rails.root.join("data/abr_pdfs/#{abbrev}/#{pdf_template_name}")
    end

    def self.pdf_template_with_cover_filename(pdf_template_name)
        pdf_template_name.gsub(/\.pdf\z/, '_with_cover.pdf')
    end

    def self.pdf_template_with_cover_path(home_state_abbrev, pdf_template_name)
        abbrev = home_state_abbrev.downcase
        Rails.root.join("data/abr_pdfs/#{abbrev}/#{pdf_template_with_cover_filename(pdf_template_name)}")
    end

    def self.pdf_cover_path 
        Rails.root.join("data/abr_coverpage/coverpage.pdf")
    end

    def self.make_cover_version(state_abbrev, pdf_template_name)
        cover_path=self.pdf_cover_path
        template_path=self.pdf_template_path(state_abbrev, pdf_template_name)
        template_with_cover_path=self.pdf_template_with_cover_path(state_abbrev, pdf_template_name)

        `pdftk #{cover_path} #{template_path} output #{template_with_cover_path}`
    end

    def self.build_coverpage_versions
        RockyConf.absentee_states.each do |state_abbrev, state_config| 
            if state_config&.pdf_template
                self.make_cover_version(state_abbrev,state_config&.pdf_template)
            end
        end
    end

    def self.run
        self.build_coverpage_versionss
    end

end