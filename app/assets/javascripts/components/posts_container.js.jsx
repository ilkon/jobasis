class PostsContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {posts: props.posts};

  }

  render() {
    const { posts } = this.state;

    const postItems = posts.map((post) =>
        <PostItem key={post.id}
            post={post} />
    );

    return (
        <ul>
          {postItems}
        </ul>
    );
  }
}
