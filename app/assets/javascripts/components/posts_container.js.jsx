class PostsContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = props;
  }

  render() {
    const { posts, paginator } = this.state;

    const postItems = posts.map((post) =>
        <PostItem key={post.id}
            post={post} />
    );

    return (
        <div>
          {
            postItems.length > 0 &&
            <ul>
              {postItems}
            </ul>
          }
          {
            postItems.length > 0 &&
            <Paginator current={paginator.current} total={paginator.total} />
          }
        </div>
    );
  }
}
