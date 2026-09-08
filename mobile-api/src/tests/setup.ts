// Test setup — use a test-specific .env
process.env.NODE_ENV = 'test';
process.env.MONGO_URI = process.env.TEST_MONGO_URI || 'mongodb://localhost:27017/kairos_test';
process.env.JWT_SECRET = 'test-secret-min-32-chars-for-zod-validation-pass';
process.env.JWT_EXPIRES_IN = '15m';
process.env.JWT_REFRESH_EXPIRES_IN = '7d';
process.env.PORT = '3001';
process.env.FASTAPI_BASE_URL = 'http://localhost:8080';
process.env.FILE_STORAGE_MODE = 'local';
process.env.UPLOAD_DIR = './uploads_test';
process.env.MAX_FILE_SIZE_MB = '25';
process.env.CORS_ORIGIN = 'http://localhost:3000';
process.env.LOG_LEVEL = 'error';
