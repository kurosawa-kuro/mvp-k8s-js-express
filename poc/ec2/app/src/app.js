const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
const routes = require('./routes');
const { logger } = require('./utils/logger');
const { errorHandler } = require('./utils/responseFormatter');

// Load environment variables
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3333;

// Swagger configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Express POC API',
      version: '1.0.0',
      description: 'API documentation for Express POC Application',
    },
    servers: [
      {
        url: `http://localhost:${PORT}`,
        description: 'Development server',
      },
    ],
  },
  apis: ['./src/routes.js'], // Path to the API routes
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));

// Routes
app.use('/api', routes);

// Error handler
app.use(errorHandler);

// Start server
app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
  logger.info(`Swagger documentation available at http://localhost:${PORT}/api-docs`);
});

module.exports = app; 