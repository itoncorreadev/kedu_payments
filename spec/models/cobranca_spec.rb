require "rails_helper"

RSpec.describe Cobranca, type: :model do
  let(:responsavel_financeiro) { create(:responsavel_financeiro) }
  let(:centro_de_custo) { create(:centro_de_custo) }
  let(:plano_de_pagamento) { create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro, centro_de_custo: centro_de_custo) }

  describe "validations" do
    it { is_expected.to validate_numericality_of(:valor_cents).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:data_vencimento) }
    it { is_expected.to validate_presence_of(:metodo_pagamento) }
  end

  describe "codigo_pagamento" do
    context "when boleto" do
      it "prefix is BOLETO-" do
        cobranca = plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.current + 5, metodo_pagamento: :boleto, status: :emitida)
        expect(cobranca.codigo_pagamento).to start_with("BOLETO-")
      end
    end

    context "when pix" do
      it "prefix is PIX-" do
        cobranca = plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.current + 5, metodo_pagamento: :pix, status: :emitida)
        expect(cobranca.codigo_pagamento).to start_with("PIX-")
      end
    end
  end

  describe "#vencida?" do
    context "when vencida" do
      it { expect(plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.yesterday, metodo_pagamento: :pix, status: :emitida).vencida?).to eq(true) }
    end
    context "when not vencida" do
      it { expect(plano_de_pagamento.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida).vencida?).to eq(false) }
    end
  end

  describe "rules" do
    context "when valor_cents is zero" do
      it do
        cobranca = plano_de_pagamento.cobrancas.new(valor_cents: 0, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
        expect(cobranca).not_to be_valid
      end
    end
  end
end
