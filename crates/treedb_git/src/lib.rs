pub mod blob;
pub mod commit;
pub mod diff;
pub mod error;
pub mod refs;
pub mod remotes;
pub mod repo;
pub mod sync;
pub mod tree;
pub mod types;

pub use error::GitError;
pub use refs::list_refs;
pub use remotes::list_remotes;
pub use repo::inspect_repository;
pub use types::*;
