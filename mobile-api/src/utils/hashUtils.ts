import crypto from 'crypto';
import fs from 'fs';
import { pipeline } from 'stream/promises';

/**
 * Compute SHA-256 hash of a Buffer (for in-memory file data)
 */
export function hashBuffer(buffer: Buffer): string {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}

/**
 * Compute SHA-256 hash of a file by streaming it (memory-efficient for large files)
 */
export async function hashFile(filePath: string): Promise<string> {
  const hash = crypto.createHash('sha256');
  const stream = fs.createReadStream(filePath);
  await pipeline(stream, hash);
  return hash.digest('hex');
}

/**
 * Constant-time comparison to prevent timing attacks when comparing hashes
 */
export function compareHashes(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(Buffer.from(a, 'hex'), Buffer.from(b, 'hex'));
}
