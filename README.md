# 🎟️ Automated Ticket Price Monitor

![Ruby](https://img.shields.io/badge/ruby-%23CC342D.svg?style=for-the-badge&logo=ruby&logoColor=white)
![Selenium](https://img.shields.io/badge/Selenium-%2300A0DC.svg?style=for-the-badge&logo=selenium&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Chrome](https://img.shields.io/badge/Google%20Chrome-4285F4?style=for-the-badge&logo=GoogleChrome&logoColor=white)

A sophisticated Ruby-based web scraping application that continuously monitors ticket resale prices and sends automated email alerts when prices drop below specified thresholds. Built with scalability in mind, featuring cloud deployment capabilities and customizable monitoring parameters.

## 🚀 Features

- **Real-time Price Monitoring**: Continuously scrapes ticket prices using Selenium WebDriver
- **Smart Email Notifications**: Automated SMTP email alerts with detailed price and quantity information  
- **Quantity-aware Alerts**: Differentiates between single tickets and bulk availability
- **Cloud-ready Architecture**: Deployable on AWS EC2 with systemd service management
- **Robust Error Handling**: Graceful fallbacks for missing page elements
- **Background Processing**: Runs as daemon process with comprehensive logging
- **Customizable Thresholds**: Easy configuration for different price points and monitoring intervals

## 🛠️ Tech Stack

**Backend & Automation:**
- Ruby 2.6+ (Core language)
- Selenium WebDriver 4.1+ (Browser automation)
- ChromeDriver (Headless browser control)

**Email & Notifications:**
- Mail gem (SMTP email delivery)
- Gmail SMTP integration
- HTML/plain text email formatting

**Environment & Configuration:**
- dotenv (Environment variable management)
- Secure credential handling

**Cloud & DevOps:**
- AWS EC2 (Cloud hosting)
- systemd (Process management)
- nohup/background processing
- Ubuntu 22.04 LTS (Production environment)

**Web Technologies:**
- CSS Selectors (Element targeting)
- DOM manipulation and parsing
- HTTP/HTTPS handling

## ⚙️ Installation & Setup

### Prerequisites
```bash
# Ruby 2.6+ and Bundler
sudo gem install bundler

# Chrome/Chromium browser
# ChromeDriver (matching your Chrome version)
```

### 1. Clone Repository
```bash
git clone https://github.com/sahana/ticket-price-monitor.git
cd ticket-price-monitor
```

### 2. Install Dependencies
```bash
bundle install
```

### 3. Configure Environment Variables
Create `.env` file:
```env
EMAIL_USERNAME=your_email@gmail.com
EMAIL_PASSWORD=your_gmail_app_password
EMAIL_TO=recipient@gmail.com
```

**Note**: Use Gmail App Password (not regular password). Enable 2FA first, then generate app-specific password in Google Account settings.

### 4. Set Up ChromeDriver
Download ChromeDriver matching your Chrome version:
- [Chrome for Testing](https://googlechromelabs.github.io/chrome-for-testing/)
- Place `chromedriver` executable in project root
- Make executable: `chmod +x chromedriver`

## 🖥️ Usage

### Local Development
```bash
# Foreground (with output)
ruby track_tickets.rb

# Background process with logging
nohup ruby track_tickets.rb > ticket_log.txt 2>&1 &

# Monitor logs
tail -f ticket_log.txt

# Stop background process
pkill -f "ruby track_tickets"
```

## ☁️ Cloud Deployment (AWS EC2)

### 1. Launch EC2 Instance
```bash
# Ubuntu 22.04 LTS, t2.micro (free tier eligible)
# Configure security group: SSH (port 22)
```

### 2. Server Setup
```bash
# Connect to instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y ruby-full build-essential git curl wget unzip

# Install Chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update && sudo apt install -y google-chrome-stable

# Install ChromeDriver
CHROME_VERSION=$(google-chrome --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
wget -O /tmp/chromedriver.zip "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}.0/linux64/chromedriver-linux64.zip"
sudo unzip /tmp/chromedriver.zip -d /usr/local/bin/
sudo chmod +x /usr/local/bin/chromedriver-linux64/chromedriver
sudo ln -s /usr/local/bin/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver
```

### 3. Deploy Application
```bash
# Upload files
scp -i your-key.pem track_tickets.rb .env Gemfile* ubuntu@your-ec2-ip:~/

# Install gems
sudo gem install selenium-webdriver mail dotenv bundler
```

### 4. Create System Service
```bash
sudo nano /etc/systemd/system/ticket-monitor.service
```

```ini
[Unit]
Description=Ticket Price Monitor
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/usr/bin/ruby track_tickets.rb
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 5. Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable ticket-monitor
sudo systemctl start ticket-monitor

# Monitor service
sudo systemctl status ticket-monitor
sudo journalctl -u ticket-monitor -f
```

## 🔧 Customization Guide

### Adapting for Other Ticket Websites

**1. Update Target URL** (Line 11):
```ruby
driver.get("YOUR_TICKET_URL_HERE")
```

**2. Modify Price Selector** (Line 19):
```ruby
# Find the CSS selector for price element
price_element = wait.until { driver.find_element(id: 'your-price-element-id') }
# or
price_element = wait.until { driver.find_element(css: '.price-class') }
```

**3. Update Quantity Selector** (Line 27):
```ruby
# Adjust quantity selector based on site structure
quantity_element = driver.find_element(css: 'your-quantity-selector')
```

**4. Adjust Price Threshold** (Line 35):
```ruby
if numeric_price < YOUR_THRESHOLD && quantity >= 1
```

**5. Customize Email Content** (Lines 55-62):
```ruby
subject "Your Custom Alert: $#{numeric_price}"
body "Your custom message with #{quantity_msg}"
```

### Finding CSS Selectors
1. Open target website in Chrome
2. Right-click price element → "Inspect"
3. Right-click in DevTools → "Copy selector"
4. Test selector in console: `document.querySelector("your-selector")`

### Common Selector Patterns
```ruby
# ID-based
driver.find_element(id: 'price-id')

# Class-based  
driver.find_element(css: '.price-class')

# Attribute-based
driver.find_element(css: '[data-testid="price"]')

# Complex selectors
driver.find_element(css: 'div.container .price-wrapper span.amount')
```

## 📊 Monitoring & Maintenance

### Log Analysis
```bash
# View recent activity
tail -50 ticket_log.txt

# Search for specific prices
grep "below.*600" ticket_log.txt

# Monitor email sends
grep "Email sent" ticket_log.txt
```

### Performance Optimization
- Adjust monitoring interval (Line 67): `sleep(30)` → `sleep(60)`
- Implement request throttling for rate limiting
- Add retry logic for network failures
- Consider using headless Chrome flags for better performance

## 🔒 Security Best Practices

- Use Gmail App Passwords (never regular passwords)
- Store credentials in `.env` files (never commit to Git)
- Implement proper error logging without exposing sensitive data
- Regular security updates for dependencies
- Use HTTPS for all external communications

## 📈 Potential Enhancements

- **Multi-site Monitoring**: Track multiple ticket sources
- **Database Integration**: Store historical pricing data
- **Web Dashboard**: Real-time monitoring interface
- **Mobile Notifications**: SMS/push notification integration
- **Machine Learning**: Price prediction algorithms
- **API Integration**: Webhook notifications to other services

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/enhancement`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/enhancement`)
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Contact

**Sahana Raja** - [sahana.raja@gmail.com](mailto:sahana.raja@gmail.com)

Project Link: [https://github.com/sahana/ticket-price-monitor](https://github.com/sahana/ticket-price-monitor)

---

⭐ **Star this repo if you found it helpful!**