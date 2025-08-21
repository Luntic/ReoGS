@echo off
ECHO Setting up Reo private server...

:: Check if Node.js is installed
ECHO Checking for Node.js...
node -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO Node.js not found! Please install Node.js from https://nodejs.org/ and try again.
    pause
    exit /b 1
)
ECHO Node.js found.

:: Check if npm is installed
ECHO Checking for npm...
npm -v >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO npm not found! Please ensure npm is installed with Node.js.
    pause
    exit /b 1
)
ECHO npm found.

:: Install project dependencies
ECHO Installing dependencies...
npm install express mongoose ws cors typescript @types/node @types/express @types/ws @types/cors --save
IF %ERRORLEVEL% NEQ 0 (
    ECHO Failed to install dependencies. Check your internet connection or npm configuration.
    pause
    exit /b 1
)
ECHO Dependencies installed.

:: Check if OpenSSL is available
ECHO Checking for OpenSSL...
openssl version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO OpenSSL not found! Please install OpenSSL or manually generate SSL certificates.
    ECHO You can download OpenSSL from https://slproweb.com/products/Win32OpenSSL.html
    pause
    exit /b 1
)
ECHO OpenSSL found.

:: Generate SSL certificates
ECHO Generating SSL certificates...
openssl genrsa -out server.key 2048
openssl req -new -x509 -key server.key -out server.cert -days 365 -subj "/C=US/ST=State/L=City/O=Reo/OU=Server/CN=localhost"
IF %ERRORLEVEL% NEQ 0 (
    ECHO Failed to generate SSL certificates. Check OpenSSL installation.
    pause
    exit /b 1
)
ECHO SSL certificates generated (server.key, server.cert).

:: Create folder structure
ECHO Creating folder structure...
mkdir src dist
IF %ERRORLEVEL% NEQ 0 (
    ECHO Failed to create folders. Check directory permissions.
    pause
    exit /b 1
)
ECHO Folder structure created.

ECHO Setup complete! Please:
ECHO 1. Copy .env.example to .env and configure your settings.
ECHO 2. Ensure MongoDB is installed and running (mongodb://localhost/reo).
ECHO 3. Run 'npm run build' to compile TypeScript.
ECHO 4. Run 'npm start' to launch the Reo server.
pause