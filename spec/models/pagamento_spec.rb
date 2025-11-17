require "rails_helper"

RSpec.describe Pagamento, type: :model do
  describe "validations" do
    it { is_expected.to validate_numericality_of(:valor_cents).is_greater_than(0) }
  end

  describe "callbacks" do
    context "when created" do
      let(:cobranca) { create(:cobranca, :vincenda, status: :emitida, valor_cents: 200_00) }
      it "marks cobrança as paga" do
        described_class.create!(cobranca:, valor_cents: 200_00, data_pagamento: Date.current)
        expect(cobranca.reload.status).to eq("paga")
      end
    end
  end

  describe "rules" do
    context "when cobrança is cancelada" do
      let(:cobranca) { create(:cobranca, :vincenda, status: :cancelada, valor_cents: 200_00) }
      subject(:pagamento) { described_class.new(cobranca:, valor_cents: 200_00, data_pagamento: Date.current) }
      it { expect(pagamento).not_to be_valid }
    end
  end

  describe "#valor_money" do
    let(:cobranca) { create(:cobranca, :vincenda, status: :emitida, valor_cents: 123_45) }
    subject(:pagamento) { described_class.new(cobranca:, valor_cents: 123_45, data_pagamento: Date.current) }

    it { expect(pagamento.valor_money.cents).to eq(12_345) }
    it { expect(pagamento.valor_money.currency.iso_code).to eq("BRL") }
  end
end
