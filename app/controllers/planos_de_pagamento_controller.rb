class PlanosDePagamentoController < ApplicationController
  before_action :set_plano, only: [ :show, :total ]

  def create
    service = PlanosDePagamento::CriarPlano.new(params: params)
    plano = service.call
    if plano
      render json: plano, status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_content
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
end
