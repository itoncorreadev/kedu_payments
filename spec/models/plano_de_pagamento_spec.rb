require "rails_helper"

RSpec.describe PlanoDePagamento, type: :model do
  describe "#calcular_total!" do
    let(:plano) { create(:plano_de_pagamento) }

    it "soma valor_cents das cobranças" do
      plano.cobrancas.create!(valor_cents: 500_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida)
      plano.cobrancas.create!(valor_cents: 300_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
      plano.calcular_total!
      expect(plano.valor_total_cents).to eq(800_00)
    end

    it "define 0 quando não há cobranças" do
      plano.calcular_total!
      expect(plano.valor_total_cents).to eq(0)
    end
  end

  describe "#total_money" do
    let(:plano) { create(:plano_de_pagamento) }
    it { expect(plano.total_money.currency.iso_code).to eq("BRL") }

    it "retorna soma das cobranças quando total_cents indisponível" do
      plano.cobrancas.create!(valor_cents: 125_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida)
      allow(plano).to receive(:respond_to?).with(:total_cents).and_return(false)
      expect(plano.total_money.cents).to eq(125_00)
    end
  end
end
