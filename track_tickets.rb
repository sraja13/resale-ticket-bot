require 'selenium-webdriver'
require 'mail'
require 'dotenv/load'

loop do
  # Set up browser
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')

  # Specify chromedriver path
  service = Selenium::WebDriver::Service.chrome(path: './chromedriver')
  driver = Selenium::WebDriver.for(:chrome, service: service, options: options)
  driver.get("https://www.ticketexchangebyticketmaster.com/grant-park-chicago/lollapalooza-tickets-chicago-il/tickets/4542048")

  wait = Selenium::WebDriver::Wait.new(timeout: 60)

  begin
    # Wait for page to load
    wait.until { driver.find_element(css: '.quantity-val') }
    
    # Find all ticket listings
    ticket_listings = driver.find_elements(css: '.quantity-val')
    puts "Found #{ticket_listings.length} ticket listings"
    
    best_single_ticket = nil
    all_tickets = []
    
    ticket_listings.each_with_index do |listing, index|
      begin
        # Get quantity for this listing
        quantity_span = listing.find_element(css: 'span:first-child')
        quantity = quantity_span.text.to_i
        
        # Get price for this listing - find the price element in the same container
        price_container = listing.find_element(xpath: './ancestor::*[contains(@class, "tmr-repeater-item") or contains(@class, "ticket-item") or contains(@class, "listing")]')
        price_element = price_container.find_element(css: '[id*="ticket-allinprice-string"], .price, [class*="price"]')
        price_text = price_element.text.strip
        numeric_price = price_text.gsub(/[^\d.]/, '').to_f
        
        ticket_info = {
          index: index + 1,
          quantity: quantity,
          price: numeric_price,
          price_text: price_text
        }
        all_tickets << ticket_info
        
        # Track best single ticket
        if quantity == 1 && (best_single_ticket.nil? || numeric_price < best_single_ticket[:price])
          best_single_ticket = ticket_info
        end
        
        puts "Listing #{index + 1}: #{quantity} ticket(s) at $#{numeric_price}"
        
      rescue => e
        puts "Error processing listing #{index + 1}: #{e.message}"
      end
    end
    
    # Report findings
    puts "\n📊 SUMMARY:"
    puts "Total listings found: #{all_tickets.length}"
    puts "Single tickets available: #{all_tickets.count { |t| t[:quantity] == 1 }}"
    
    if best_single_ticket
      puts "🎯 Best single ticket: $#{best_single_ticket[:price]}"
      
      # Check if we should send alert
      if best_single_ticket[:price] < 670
        puts "📬 Single ticket under $670 found! Sending email..."
        
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
          subject "🔥 Lolla Ticket Alert: $#{best_single_ticket[:price]} - 1 ticket"
          body <<~BODY
            A single resale ticket is now available for $#{best_single_ticket[:price]}!
            
            Check the link here:
            https://www.ticketexchangebyticketmaster.com/grant-park-chicago/lollapalooza-tickets-chicago-il/tickets/4542048
          BODY
        end

        puts "✅ Email sent!"
      else
        puts "ℹ️ Best single ticket ($#{best_single_ticket[:price]}) is above $670 threshold."
      end
    else
      puts "❌ No single tickets available - only group tickets found."
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

