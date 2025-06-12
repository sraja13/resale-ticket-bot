require 'selenium-webdriver'
require 'mail'
require 'dotenv/load'

loop do
  # Set up browser
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')

  driver = Selenium::WebDriver.for(:chrome, options: options)
  driver.get("https://www.ticketexchangebyticketmaster.com/grant-park-chicago/lollapalooza-tickets-chicago-il/tickets/4542048")

  wait = Selenium::WebDriver::Wait.new(timeout: 60)

  begin
    # Wait for ticket price element to appear
    price_element = wait.until { driver.find_element(id: 'ticket-allinprice-string-16') }

    # Extract price and convert to float
    price_text = price_element.text.strip
    puts "Ticket price loaded: #{price_text}"

    # Remove non-numeric characters and convert to float
    numeric_price = price_text.gsub(/[^\d.]/, '').to_f 
    puts "Numeric price: $#{numeric_price}"

    # Check price threshold
    if numeric_price < 600
      puts "📬 Price is below $600! Sending email..."

      Mail.defaults do
        delivery_method :smtp, {
          address: "smtp.gmail.com",
          port: 587,
          user_name: ENV['EMAIL_USERNAME'],
          password: ENV['EMAIL_PASSWORD'],
          authentication: 'plain',
          enable_starttls_auto: true
        }
      end

      Mail.deliver do
        to ENV['EMAIL_TO']
        from ENV['EMAIL_USERNAME']
        subject "🔥 Lolla Ticket Alert: $#{numeric_price}"
        body <<~BODY
          A resale ticket is now available for $#{numeric_price}!

          Check the link here:
          https://www.ticketexchangebyticketmaster.com/grant-park-chicago/lollapalooza-tickets-chicago-il/tickets/4542048
        BODY
      end

      puts "✅ Email sent!"
    else
      puts "ℹ️ Price is above $600, no email sent."
    end

  rescue Selenium::WebDriver::Error::TimeoutError
    puts "❌ Timed out waiting for ticket price element"
    puts driver.page_source[0..2000]
  ensure
    driver.quit
  end

  puts "⏳ Waiting 30 seconds before checking again..."
  sleep(30) # Wait 30 sec
end

