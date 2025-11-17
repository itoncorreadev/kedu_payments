require "rails_helper"

RSpec.describe "Cobranças - filtros", type: :request do
  describe "GET /responsaveis/:id/cobrancas" do
    let(:responsavel_financeiro) { create(:responsavel_financeiro) }
    let(:centro_de_custo) { create(:centro_de_custo) }
    let(:plano_de_pagamento) { create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro, centro_de_custo: centro_de_custo) }

    context "when metodoPagamento is boleto" do
      before do
        plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida)
        plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
        get "/responsaveis/#{responsavel_financeiro.id}/cobrancas", params: { metodoPagamento: "boleto" }
      end
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body).size).to eq(1) }
    end

    context "when status is emitida" do
      before do
        plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
        plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :paga)
        get "/responsaveis/#{responsavel_financeiro.id}/cobrancas", params: { status: "emitida" }
      end
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body).all? { |c| c["status"] == "emitida" }).to eq(true) }
    end

    context "when metodoPagamento is invalid" do
      before do
        plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
        get "/responsaveis/#{responsavel_financeiro.id}/cobrancas", params: { metodoPagamento: "cartao" }
      end
      it { expect(response).to have_http_status(:ok) }
      it { expect(JSON.parse(response.body)).to eq([]) }
    end
  end
end
