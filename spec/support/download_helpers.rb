module DownloadHelpers
  TIMEOUT = 10
  PATH = Rails.root.join('tmp', 'downloads')

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep(0.1) until downloaded?
    end
  end

  def downloads(pattern = '*')
    Dir.glob(PATH.join(pattern))
  end

  def downloaded?
    !downloading? && downloads.any?
  end

  def downloading?
    downloads.grep(/\.crdownload\z/).any?
  end

  def clear_downloads
    FileUtils.rm_rf(downloads)
  end
end
