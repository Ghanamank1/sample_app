class ChangeDataTypeForResetSentAt < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :reset_sent_at, :datetime
  end
end
