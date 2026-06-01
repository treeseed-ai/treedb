use thiserror::Error;

#[derive(Debug, Error)]
pub enum GitError {
    #[error("io error: {0}")]
    Io(#[from] std::io::Error),
    #[error("git error: {0}")]
    Git(String),
}

impl GitError {
    pub fn code(&self) -> &'static str {
        match self {
            GitError::Io(_) => "io_error",
            GitError::Git(_) => "git_error",
        }
    }
}
