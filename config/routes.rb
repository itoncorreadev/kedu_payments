Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :responsaveis, controller: :responsaveis, only: [ :index, :create, :show ] do
    resources :planos_de_pagamento, only: [ :index ]
    get "cobrancas", to: "cobrancas#index_por_responsavel"
    get "cobrancas/quantidade", to: "cobrancas#quantidade_por_responsavel"
  end

  resources :planos_de_pagamento, path: "planos-de-pagamento", only: [ :create, :show ] do
    get "total", on: :member
  end

  resources :cobrancas, only: [] do
    resources :pagamentos, only: [ :create ]
  end

  resources :centros_de_custo, path: "centros-de-custo", only: [ :create, :index ]
end
