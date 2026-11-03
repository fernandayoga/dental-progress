import { connectDatabase, disconnectDatabase } from '../config/db.js';
import { seedDatabase } from '../utils/seedData.js';
import { logger } from '../utils/logger.js';

async function main() {
  try {
    await connectDatabase();
    await seedDatabase({ force: process.argv.includes('--force') });
    logger.info('Database seeding process finished.');
  } catch (error) {
    logger.error('Database seeding failed:', error);
    process.exit(1);
  } finally {
    await disconnectDatabase();
    process.exit(0);
  }
}

main();
