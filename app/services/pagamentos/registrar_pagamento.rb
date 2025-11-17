module Pagamentos
  class RegistrarPagamento
    attr_reader :errors, :pagamento

    def initialize(cobranca:, params:, request: nil)
      @cobranca = cobranca
      @params = params
      @request = request
      @errors = []
    end

    def call
      attrs = build_attrs
      @pagamento = @cobranca.pagamentos.build(attrs)
      if @pagamento.save
        @pagamento
      else
        @errors = @pagamento.errors.full_messages
        nil
      end
    end

    private

    def build_attrs
      p = normalize(@params)
      valor_param = p[:valor] || p["valor"]
      if blank?(valor_param) && @request
        body = @request.request_parameters
        valor_param = body["valor"] || dig(body, "pagamento", "valor") || dig(body, "payload", "valor")
      end
      valor_cents_param = p[:valor_cents] || p["valor_cents"]
      valor_cents = present?(valor_param) ? to_cents(valor_param) : valor_cents_param.to_i
      {
        valor_cents: valor_cents,
        data_pagamento: (p[:data_pagamento] || p[:dataPagamento] || Date.current)
      }
    end

    def normalize(params)
      if params.respond_to?(:to_unsafe_h)
        params.to_unsafe_h
      else
        params.to_h
      end
    end

    def to_cents(valor)
      return 0 if blank?(valor)
      Money.from_amount(BigDecimal(valor.to_s), "BRL").cents
    end

    def blank?(v)
      v.nil? || v == ""
    end

    def present?(v)
      !blank?(v)
    end

    def dig(hash, *keys)
      keys.reduce(hash) { |h, k| h.respond_to?(:[]) ? h[k] : nil }
    end
  end
end
