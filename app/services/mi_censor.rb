class MiCensor

  def self.client_id
    'mi_client'
  end

  def self.protect(params)
    # TODO mask sensitive data
    params
  end
end
