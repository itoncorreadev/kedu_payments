class PlanosDePagamentoController < ApplicationController
  before_action :set_plano, only: [ :show, :total ]

  def create
    plano_params = if params[:plano_de_pagamento].present?
      create_plano_params
    else
      {
        responsavel_financeiro_id: params[:responsavelId] || params[:responsavel_id],
        centro_de_custo_id: params[:centroDeCusto] || params[:centro_de_custo_id],
        cobrancas_attributes: Array(params[:cobrancas]).map { |c| sanitize_cobranca_attributes(c) }
      }
    end

    @plano = PlanoDePagamento.new(plano_params)

    if @plano.save
      @plano.calcular_total!
      render json: @plano, status: :created
    else
      render json: { errors: @plano.errors.full_messages }, status: :unprocessable_content
    end
  end

  def show
    render json: @plano
  end

  def total
    total = (@plano.valor_total_cents.to_f / 100.0)
    render json: { total: total.to_s }
  end

  def index
    responsavel_id = params[:responsavel_id] || params[:responsavei_id] || params[:id]
    @planos = PlanoDePagamento.where(responsavel_financeiro_id: responsavel_id)
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
