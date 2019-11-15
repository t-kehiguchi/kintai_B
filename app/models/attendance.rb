class Attendance < ApplicationRecord
  belongs_to :user
  validates :worked_on,  presence: true
  validate :started_saved_when_finished_save
  validate :started_earlier_than_finished

  def started_saved_when_finished_save
    if finished_at.present?
      if !started_at.present?
        errors.add(:started_at, "は退社時間を保存する時に存在しないといけません。")
      end
    end
  end

  def started_earlier_than_finished
    if started_at.present? && finished_at.present?
      if started_at > finished_at
        errors.add(:started_at, "よりも遅い時間にしないといけません。")
      end
    end
  end

end
