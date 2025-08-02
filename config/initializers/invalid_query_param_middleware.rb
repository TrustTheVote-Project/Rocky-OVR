require Rails.root.join('app/middleware/invalid_query_param_middleware')
Rails.application.config.middleware.use InvalidQueryParamMiddleware