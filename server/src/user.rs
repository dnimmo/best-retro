use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct User {
    pub id: &'static str,
    pub name: &'static str,
    pub email: &'static str,
    pub teams: [&'static str; 2],
}

pub const TEST_USER: User = User {
    id: "1",
    name: "Nimmo",
    email: "dnimmo@gmail.com",
    teams: ["1", "2"],
};