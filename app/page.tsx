import { getUser } from "@/lib/actions/user";

export default async function Home() {
  const users = await getUser();
  return (
    <div>
      <h1>Users</h1>
      <ul>
        {users.map(
          (user: { id: number; email: string; name: string | null }) => (
            <li key={user.id}>
              {user.name} - {user.email}
            </li>
          ),
        )}
      </ul>
    </div>
  );
}
