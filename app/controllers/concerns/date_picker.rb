module DatePicker
  extend ActiveSupport::Concern

  def date_picker
    {
      start: (oldest = Crawl.oldest) ? oldest.started_at.to_date : Date.current,
      end: (latest = Crawl.latest) ? latest.started_at.to_date : Date.current,
      current: begin
        params[:date].present? ? Date.parse(params[:date]) : latest.started_at.to_date
      rescue
        latest.started_at.to_date || Date.current
      end
    }
  end
end
