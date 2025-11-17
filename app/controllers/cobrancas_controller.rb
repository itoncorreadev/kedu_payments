class CobrancasController < ApplicationController
  def index_por_responsavel
    responsavel_id = params[:responsavel_id] || params[:responsavei_id] || params[:id]
    plano_ids = PlanoDePagamento.where(responsavel_financeiro_id: responsavel_id.to_i).pluck(:id)
    cobrancas = Cobranca.where(plano_de_pagamento_id: plano_ids)
    cobrancas = cobrancas.por_metodo_pagamento(params[:metodoPagamento]) if params[:metodoPagamento].present?
    cobrancas = cobrancas.por_status(params[:status]) if params[:status].present?
    cobrancas = cobrancas.vencidas if params[:vencida] == "true"
    render json: cobrancas, each_serializer: CobrancaSerializer
  end

  def quantidade_por_responsavel
    responsavel_id = params[:responsavel_id] || params[:responsavei_id] || params[:id]
    plano_ids = PlanoDePagamento.where(responsavel_financeiro_id: responsavel_id.to_i).pluck(:id)
    count = Cobranca.where(plano_de_pagamento_id: plano_ids).count
    render json: { quantidade: count }
  end
end
