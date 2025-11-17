class PlanosDePagamentoController < ApplicationController
  before_action :set_plano, only: [ :show, :total ]

  # POST /planos_de_pagamento
  def create
    # Usando strong params e um método privado para preparar os atributos
    plano_params = create_plano_params

    @plano = PlanoDePagamento.new(plano_params)

    if @plano.save
      # A chamada para calcular_total! pode ser movida para um callback no modelo
      @plano.calcular_total!
      render json: @plano.as_json(include: :cobrancas), status: :created
    else
      render json: { errors: @plano.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /planos_de_pagamento/:id
  def show
    render json: @plano.as_json(include: :cobrancas)
  end

  # GET /planos_de_pagamento/:id/total
  def total
    # Simplificado assumindo que o modelo tem um método total_value
    render json: { total: @plano.total_value.to_s }
  end

  # GET /planos_de_pagamento
  def index
    # Assumindo que a relação existe: Responsavel.find(params[:responsavel_id]).planos_de_pagamento
    @planos = PlanoDePagamento.where(responsavel_financeiro_id: params[:responsavel_id])
                              .includes(:centro_de_custo)
    render json: @planos
  end

  private

  # Define o plano de pagamento para show e total, lidando com RecordNotFound
  def set_plano
    @plano = PlanoDePagamento.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Plano de Pagamento não encontrado" }, status: :not_found
  end

  # Define strong parameters para a ação create
  def create_plano_params
    params.require(:plano_de_pagamento).permit(
      :responsavel_financeiro_id,
      :centro_de_custo_id,
      cobrancas_attributes: [ :valor, :valor_cents, :data_vencimento, :metodo_pagamento, :dataVencimento, :metodoPagamento ]
    ).tap do |whitelisted_params|
      # Mapeia e sanitiza os atributos aninhados de cobrancas
      if whitelisted_params[:cobrancas_attributes].present?
        whitelisted_params[:cobrancas_attributes] = whitelisted_params[:cobrancas_attributes].map do |c_attrs|
          sanitize_cobranca_attributes(c_attrs)
        end
      end
    end
  end

  # Helper privado para garantir a consistência dos atributos de cobranca
  def sanitize_cobranca_attributes(attrs)
    valor = attrs[:valor] || attrs[:valor_cents]
    # Usando um método to_cents mais robusto
    valor_cents = to_cents(valor)

    {
      valor_cents: valor_cents,
      data_vencimento: attrs[:data_vencimento] || attrs[:dataVencimento],
      metodo_pagamento: (attrs[:metodo_pagamento] || attrs[:metodoPagamento]).to_s.downcase
    }
  end

  # Helper para converter valores (float, string) para cents (inteiro) de forma segura
  def to_cents(valor)
    return 0 if valor.blank?
    # BigDecimal é a melhor prática para lidar com dinheiro para evitar erros de ponto flutuante
    (BigDecimal(valor.to_s) * 100).to_i
  end
end
