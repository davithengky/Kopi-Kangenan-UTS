# Kopi-Kangenan-Backend-Laravel

Backend API for Kopi Kangenan application built with Laravel.

## Table of Contents

- [About the Project](#about-the-project)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [API Endpoints](#api-endpoints)
- [Database](#database)
- [Environment Variables](#environment-variables)
- [License](#license)

## About the Project

**Kopi-Kangenan-Backend-Laravel** is a Laravel-based backend API for the Kopi Kangenan application. This project provides the server-side logic, API endpoints, and database management for the Kopi Kangenan system.

## Features

- User authentication and authorization
- Product and catalog management
- Order processing system
- Payment integration
- Voucher and promotion system
- Membership management
- Inbox/messaging system
- Bulk order handling
- Daily check-in rewards
- Outlet management

## Prerequisites

- PHP >= 8.1
- Composer
- Node.js & npm
- MySQL or PostgreSQL database
- Git

## Installation

```bash
# Clone the repository
git clone https://github.com/davithengky/Kopi-Kangenan-Backend-Laravel.git

# Navigate to the project directory
cd Kopi-Kangenan-Backend-Laravel

# Install PHP dependencies
composer install

# Install Node.js dependencies
npm install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Compile assets
npm run build
```

## Configuration

Update the `.env` file with your database and application settings:

```
APP_NAME=Kopi-Kangenan-Backend-Laravel
APP_ENV=local
APP_KEY=base64:your_key_here
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=copikangenan
DB_USERNAME=root
DB_PASSWORD=

# Mail configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=hello@example.com
MAIL_FROM_NAME="${APP_NAME}"

# Other config...
```

## Running the Application

```bash
# Development server
php artisan serve

# Or use Laravel Valet
valet link

# Run queue workers
php artisan queue:work

# Run scheduled tasks
php artisan schedule:run
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/user` - Get authenticated user

### Products
- `GET /api/products` - List all products
- `GET /api/products/{id}` - Get product details
- `POST /api/products` - Create product (admin)
- `PUT /api/products/{id}` - Update product (admin)
- `DELETE /api/products/{id}` - Delete product (admin)

### Orders
- `GET /api/orders` - List user orders
- `POST /api/orders` - Create new order
- `GET /api/orders/{id}` - Get order details
- `PUT /api/orders/{id}/status` - Update order status

### Other Endpoints
- `GET /api/categories` - List categories
- `GET /api/outlets` - List outlets
- `GET /api/vouchers` - List vouchers
- `POST /api/checkin` - Daily check-in
- `GET /api/membership` - Membership info

## Database

Run migrations to set up the database:

```bash
php artisan migrate
```

Seeders are available to populate initial data:

```bash
php artisan db:seed
```

Or run all seeders:

```bash
php artisan serve
```

## Environment Variables

Key environment variables from `.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_ENV` | Environment (local, production) | local |
| `APP_DEBUG` | Debug mode | true |
| `DB_DATABASE` | Database name | copikangenan |
| `DB_USERNAME` | Database username | root |
| `MAIL_MAILER` | Mail sender type | smtp |
| `CACHE_DRIVER` | Cache driver | file |
| `QUEUE_CONNECTION` | Queue connection | sync |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.