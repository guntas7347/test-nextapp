import prisma from "@/prisma/prisma";

export const getUser = async () => {
  return await prisma.user.findMany();
};
export const createUser = async () => {
  return await prisma.user.create({
    data: {
      email: "[EMAIL_ADDRESS]",
      name: "Guntas",
    },
  });
};
