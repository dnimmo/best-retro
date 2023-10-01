use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct User {
    pub id: &'static str,
    pub name: &'static str,
    pub email: &'static str,
    pub teams: [&'static str; 2],
}

pub const TEST_USER: User = User {
    id: "c72c207b-0847-386d-bdbc-2e5def81cf81",
    name: "Nimmo",
    email: "dnimmo@gmail.com",
    teams: ["c72c207b-0847-386d-bdbc-2e5def81cf83", "c72c207b-0847-386d-bdbc-2e5def81cf84"],
};