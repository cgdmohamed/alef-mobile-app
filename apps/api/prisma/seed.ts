import 'dotenv/config';
import { PrismaClient, StaffRole } from '@prisma/client';
import { hash } from 'argon2';

const prisma = new PrismaClient();

async function main(): Promise<void> {
  const email = process.env.INITIAL_ADMIN_EMAIL?.trim().toLowerCase();
  const password = process.env.INITIAL_ADMIN_PASSWORD;
  const name = process.env.INITIAL_ADMIN_NAME?.trim();
  if (!email || !password || password.length < 12 || !name) throw new Error('Valid INITIAL_ADMIN_EMAIL, INITIAL_ADMIN_PASSWORD, and INITIAL_ADMIN_NAME are required');
  const user = await prisma.user.upsert({
    where: { email },
    create: { email, name, passwordHash: await hash(password) },
    update: {},
  });
  const existingRole = await prisma.staffMembership.findFirst({
    where: { userId: user.id, schoolId: null, role: StaffRole.ALIF_SUPER_ADMIN },
  });
  if (!existingRole) {
    await prisma.staffMembership.create({ data: { userId: user.id, role: StaffRole.ALIF_SUPER_ADMIN } });
  }
}

main().finally(() => prisma.$disconnect());
