module PlanosDePagamento
  class CriarPlano
    attr_reader :errors, :plano

    def initialize(params:)
      @params = params
      @errors = []
    end

    def call
      p = build_params(@params)
      @plano = ::PlanoDePagamento.new(p)
      if @plano.save
        @plano.calcular_total!
        @plano
      else
        @errors = @plano.errors.full_messages
        nil
      end
    end

    private

    def build_params(params)
      if params[:plano_de_pagamento].present?
        permitted = params.require(:plano_de_pagamento).permit(
          :responsavel_financeiro_id,
          :centro_de_custo_id,
          cobrancas_attributes: [ :valor, :valor_cents, :data_vencimento, :metodo_pagamento, :dataVencimento, :metodoPagamento ]
        )
        if permitted[:cobrancas_attributes].present?
          permitted[:cobrancas_attributes] = permitted[:cobrancas_attributes].map { |c| sanitize_cobranca_attributes(c) }
        end
        permitted
      else
        {
          responsavel_financeiro_id: params[:responsavelId] || params[:responsavel_id],
          centro_de_custo_id: params[:centroDeCusto] || params[:centro_de_custo_id],
          cobrancas_attributes: Array(params[:cobrancas]).map { |c| sanitize_cobranca_attributes(c) }
        }
      end
    end

    def sanitize_cobranca_attributes(attrs)
      valor = attrs[:valor] || attrs[:valor_cents]
      {
        valor_cents: to_cents(valor),
        data_vencimento: attrs[:data_vencimento] || attrs[:dataVencimento],
        metodo_pagamento: (attrs[:metodo_pagamento] || attrs[:metodoPagamento]).to_s.downcase
      }
    end

    def to_cents(valor)
      return 0 if valor.nil? || valor == ""
      Money.from_amount(BigDecimal(valor.to_s), "BRL").cents
    end
  end
end
