class CrawlerMailer < ApplicationMailer
  if (from = ENV['UMAKADATA_MAILER_CRAWL_MAILER_FROM'])
    default from: from
  end

  default subject: 'Crawler notification'

  def notify_finished_to(user, crawl)
    @user = user
    @crawl = crawl

    date = Time.current < Crawl.start_time(Date.current) ? Date.current : Date.current.succ
    @next_crawl = loop do
      c = Crawl.find_by(started_at: date.beginning_of_day..date.end_of_day)
      break Crawl.start_time(date) if !c || (c && !c.skip)
      date = date.succ
    end

    base = Measurement.includes(:activities).where(started_at: crawl.started_at..crawl.finished_at)
    @measurement_with_exceptions = base.where.not(exceptions: nil).or(base.where.not(activities: { exceptions: nil }))

    mail to: user.email
  end
end
