# 🎟️ Ticket Price Tracker

![Ruby](https://img.shields.io/badge/ruby-%23CC342D.svg?style=for-the-badge&logo=ruby&logoColor=white)
![Selenium](https://img.shields.io/badge/Selenium-%2300A0DC.svg?style=for-the-badge&logo=selenium&logoColor=white)

**Ticket Price Tracker** is a Ruby script that scrapes ticket resale prices from Ticketmaster Ticket Exchange and sends you email alerts when prices drop below a threshold.

---

## 🚀 Features

- Scrapes resale ticket prices from Ticketmaster using Selenium WebDriver.
- Sends email notifications if ticket prices go below your target price.
- Runs periodically (looped script).

## ⚙️ Setup Instructions

### 1. Install Dependencies

Make sure you have Ruby and Bundler installed. Then install required gems:

bash
bundle install

### 2. Add ChromeDriver to Project Folder

Download the correct version of [ChromeDriver] and place it in the **root folder** of the project. This is required for Selenium to run the browser in headless mode.

### 3. Create a `.env` File

Create a file named `.env` in the root directory of the project, and add your email credentials:

```bash
EMAIL_USERNAME=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
EMAIL_TO=recipient_email@gmail.com
```

## 🖥️ Run the Script

Run the script from your terminal:

bash
ruby ticket_tracker.rb

