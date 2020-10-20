class AbrPdfCoverPageMerger
    
    def pdf_template_path (home_state_abbrev, pdf_template)
        abbrev = home_state_abbrev.downcase
        Rails.root.join("data/abr_pdfs/#{abbrev}/#{pdf_template_name}")
    end

    def pdf_template_with_cover_filename(pdf_template_name)
        pdf_template_name.gsub(/\.pdf\z/, '_with_cover.pdf')
    end

    def pdf_template_with_cover_path (home_state_abbrev, pdf_template)
        abbrev = home_state_abbrev.downcase
        Rails.root.join("data/abr_pdfs/#{abbrev}/#{pdf_template_with_cover_filename}")
    end

    def pdf_cover_path 
        Rails.root.join("data/abr_pdfs/abr_coverpage/coverpage.pdf")
    end

    def make_cover_version(state_abbrev, pdf_template)
        `pdftk #{pdf_cover_path} #{pdf_template_path(home_state_abbrev, pdf_template)} output #{pdf_template_with_cover_path(home_state_abbrev, pdf_template)}`
    end

    def build_coverpage_versions
        RockyConf.absentee_states.each do |state_abbrev, state_config| 
            if state_config&.pdf_template
                make_cover_version(state_abbrev,state_config&.pdf_template)
            end
        end
    end

    def self.run
        build_coverpage_versions
    end

end