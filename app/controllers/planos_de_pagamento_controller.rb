class PlanosDePagamentoController < ApplicationController
  before_action :set_plano, only: [ :show, :total ]

  def create
    plano_params = create_plano_params

    @plano = PlanoDePagamento.new(plano_params)

    if @plano.save
      @plano.calcular_total!
      render json: @plano.as_json(include: :cobrancas), status: :created
    else
      render json: { errors: @plano.errors.full_messages }, status: :unprocessable_content
    end
  end

  def show
    render json: @plano.as_json(include: :cobrancas)
  end

  def total
    render json: { total: @plano.total_value.to_s }
  end

  def index
    @planos = PlanoDePagamento.where(responsavel_financeiro_id: params[:responsavel_id])
                              .includes(:centro_de_custo)
    render json: @planos
  end

  private

  def set_plano
    @plano = PlanoDePagamento.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Plano de Pagamento não encontrado" }, status: :not_found
  end

  def create_plano_params
    params.require(:plano_de_pagamento).permit(
      :responsavel_financeiro_id,
      :centro_de_custo_id,
      cobrancas_attributes: [ :valor, :valor_cents, :data_vencimento, :metodo_pagamento, :dataVencimento, :metodoPagamento ]
    ).tap do |whitelisted_params|
      if whitelisted_params[:cobrancas_attributes].present?
        whitelisted_params[:cobrancas_attributes] = whitelisted_params[:cobrancas_attributes].map do |c_attrs|
          sanitize_cobranca_attributes(c_attrs)
        end
      end
    end
  end

  def sanitize_cobranca_attributes(attrs)
    valor = attrs[:valor] || attrs[:valor_cents]
    valor_cents = to_cents(valor)

    {
      valor_cents: valor_cents,
      data_vencimento: attrs[:data_vencimento] || attrs[:dataVencimento],
      metodo_pagamento: (attrs[:metodo_pagamento] || attrs[:metodoPagamento]).to_s.downcase
    }
  end

  def to_cents(valor)
    return 0 if valor.blank?
    Money.from_amount(BigDecimal(valor.to_s), "BRL").cents
  end
end
