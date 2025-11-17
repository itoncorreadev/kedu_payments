require "rails_helper"

RSpec.describe PlanoDePagamento, type: :model do
  describe "#calcular_total!" do
    let(:plano_de_pagamento) { create(:plano_de_pagamento) }

    it "soma valor_cents das cobranças" do
      plano_de_pagamento.cobrancas.create!(valor_cents: 500_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida)
      plano_de_pagamento.cobrancas.create!(valor_cents: 300_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
      plano_de_pagamento.calcular_total!
      expect(plano_de_pagamento.total_cents || (plano_de_pagamento.valor_total * 100).to_i).to eq(800_00)
    end
  end

  describe "#total_money" do
    let(:plano_de_pagamento) { create(:plano_de_pagamento) }
    it { expect(plano_de_pagamento.total_money.currency.iso_code).to eq("BRL") }
  end
end
