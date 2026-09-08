import { z } from 'zod';

export const loginSchema = z.object({
  identifier: z.string().min(1, 'Employee ID or email is required'),
  password: z.string().min(1, 'Password is required'),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

export const logoutSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});
