require "rails_helper"

RSpec.describe "Registro de Pagamento", type: :request do
  describe "POST /cobrancas/:id/pagamentos" do
    context "when valid" do
      let(:responsavel_financeiro) { create(:responsavel_financeiro) }
      let(:centro_de_custo) { create(:centro_de_custo) }
      let(:plano_de_pagamento) { create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro, centro_de_custo: centro_de_custo) }
      let(:cobranca) { plano_de_pagamento.cobrancas.create!(valor_cents: 500_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida) }
      before { post "/cobrancas/#{cobranca.id}/pagamentos", params: { valor: 500.0, data_pagamento: Date.current } }
      it { expect(response).to have_http_status(:created) }
      it { expect(cobranca.reload.status).to eq("paga") }
    end

    context "when canceled" do
      let(:responsavel_financeiro) { create(:responsavel_financeiro) }
      let(:centro_de_custo) { create(:centro_de_custo) }
      let(:plano_de_pagamento) { create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro, centro_de_custo: centro_de_custo) }
      let(:cobranca) { plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :cancelada) }
      before { post "/cobrancas/#{cobranca.id}/pagamentos", params: { valor: 100.0, data_pagamento: Date.current } }
      it { expect(response).to have_http_status(:unprocessable_content) }
    end

    context "when not found" do
      before { post "/cobrancas/999999/pagamentos", params: { valor: 10.0, data_pagamento: Date.current } }
      it { expect(response).to have_http_status(:not_found) }
    end

    context "when zero value" do
      let(:responsavel_financeiro) { create(:responsavel_financeiro) }
      let(:centro_de_custo) { create(:centro_de_custo) }
      let(:plano_de_pagamento) { create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro, centro_de_custo: centro_de_custo) }
      let(:cobranca) { plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida) }
      before { post "/cobrancas/#{cobranca.id}/pagamentos", params: { valor: 0, data_pagamento: Date.current } }
      it { expect(response).to have_http_status(:unprocessable_content) }
    end
  end
end
