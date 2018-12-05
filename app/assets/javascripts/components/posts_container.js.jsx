class PostsContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {posts: props.posts};

  }

  render() {
    const { posts } = this.state;

    const postItems = posts.map((post) =>
        <PostItem key={post.id}
            rawText={post.raw_text} />
    );

    return (
        <ul>
          {postItems}
        </ul>
    );
  }
}
