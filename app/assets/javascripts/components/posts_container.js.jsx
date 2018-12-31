class PostsContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = props;

    this.handlePageChange = this.handlePageChange.bind(this);
  }

  handlePageChange(page) {
    this.setState(prevState => ({
      paginator: { ...prevState.paginator, current: page }
    }));

    this.setState({loading: true});

    let url = new URL(window.location.href);
    url.pathname = 'posts.json';
    url.searchParams.set('page', page);

    fetch(url, {
      cache: 'no-cache',
      credentials: 'same-origin',
      headers: {
        'content-type': 'application/json'
      },
      method: 'GET',
      mode: 'cors',
      redirect: 'follow',
      referrer: 'no-referrer',
    })
        .then(response => {
          if (response.ok) {
            response.json().then(data => {
              this.setState({
                loading: false,
                posts: data.data.posts
              });
            }).then(() => {
              window.scrollTo({
                top: 0,
                left: 0,
                behavior: 'auto'
              });
            });
          } else {
            response.json().then(data => {
              this.setState({
                loading: false,
                errors: data.errors
              });
            });
          }
        });
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
            <Paginator current={paginator.current} total={paginator.total} handlePageChange={this.handlePageChange} />
          }
        </div>
    );
  }
}
