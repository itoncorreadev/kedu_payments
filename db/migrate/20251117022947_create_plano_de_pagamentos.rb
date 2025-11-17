class CreatePlanoDePagamentos < ActiveRecord::Migration[8.1]
  def change
    create_table :plano_de_pagamentos do |t|
      t.references :responsavel_financeiro, null: false, foreign_key: true
      t.references :centro_de_custo, null: false, foreign_key: true
      t.integer :valor_total_cents, null: false, default: 0

      t.timestamps
    end
  end
end
