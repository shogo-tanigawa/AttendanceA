class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

  # 出社時間が存在しない場合、退社時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出社・退社時間どちらも存在し、翌日チェックがない時、出社時間より早い退社時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  # 出社変更・退社変更時間どちらも存在し、翌日チェックがない時、出社変更時間より早い退社変更時間は無効
  validate :restarted_at_than_refinished_at_fast_if_invalid

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present? && !next_day.present?
      errors.add(:started_at, "より早い退勤時間は無効です。") if started_at > finished_at
    end
  end

  def restarted_at_than_refinished_at_fast_if_invalid
    if restarted_at.present? && refinished_at.present? && !next_day.present?
      errors.add(:started_at, "より早い退勤時間は無効です。") if restarted_at > refinished_at
    end
  end
end