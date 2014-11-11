module Grell
require 'byebug'
  # This class depends heavily on Capybara but contains no logic.
  class RawPage
    include Capybara::DSL

    def navigate(url)
      visit(url)
    end

    def headers
      page.response_headers
    end

    def status
      page.status_code
    end

    def body
      page.body
    end

    def all_links
      all('a', visible: false)
    end

    def host
      page.current_host
    end
  end
end