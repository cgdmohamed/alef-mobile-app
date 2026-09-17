import Joi from 'joi';

export const envSchema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'test', 'production').default('development'),
  PORT: Joi.number().port().default(3000),
  DATABASE_URL: Joi.string().uri({ scheme: ['postgresql', 'postgres'] }).required(),
  REDIS_URL: Joi.string().uri({ scheme: ['redis', 'rediss'] }).required(),
  JWT_ACCESS_SECRET: Joi.string().min(32).required(),
  JWT_ACCESS_TTL_SECONDS: Joi.number().integer().min(60).max(86_400).default(900),
  REFRESH_TOKEN_DAYS: Joi.number().integer().min(1).max(365).default(30),
  STUDENT_CODE_PEPPER: Joi.string().min(32).required(),
  INITIAL_ADMIN_EMAIL: Joi.string().email().required(),
  INITIAL_ADMIN_PASSWORD: Joi.string().min(12).required(),
  INITIAL_ADMIN_NAME: Joi.string().min(2).required(),
  ALLOWED_ORIGINS: Joi.string().required(),
});
