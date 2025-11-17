module Cobrancas
  class ConsultaPorResponsavel
    def initialize(params:)
      @params = params
    end

    def listar
      responsavel_id = @params[:responsavel_id] || @params[:responsavei_id] || @params[:id]
      rel = ::Cobranca.por_responsavel(responsavel_id)
      if present?(@params[:metodoPagamento])
        rel = rel.por_metodo_pagamento(@params[:metodoPagamento])
      end
      if present?(@params[:status])
        rel = rel.por_status(@params[:status])
      end
      if @params[:vencida] == "true"
        rel = rel.vencidas
      end
      rel
    end

    def contar
      responsavel_id = @params[:responsavel_id] || @params[:responsavei_id] || @params[:id]
      plano_ids = ::PlanoDePagamento.where(responsavel_financeiro_id: responsavel_id.to_i).pluck(:id)
      ::Cobranca.where(plano_de_pagamento_id: plano_ids).count
    end

    private

    def present?(v)
      !(v.nil? || v == "")
    end
  end
end
