class PartnerAssetsPresenter
  attr_reader :approved, :not_approved

  PREVIEW_FILTER = ->(v) { v.starts_with?('preview/') }
  PREVIEW_REMOVER = ->(v) { v.gsub(%r(^preview\/), '') }

  def initialize(partner)
    assets_raw = Rails.cache.fetch("partner/#{partner.id}/assets", expires_in: 10.minutes) do
      PartnerAssetsFolder.new(partner).list_assets
    end

    @approved = assets_raw.reject(&PREVIEW_FILTER).sort
    @not_approved = assets_raw.select(&PREVIEW_FILTER).map(&PREVIEW_REMOVER).sort
  end
end