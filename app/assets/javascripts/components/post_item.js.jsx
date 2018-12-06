function PostItem(props) {
  const { post } = props;

  return <li>
    <b>{post.employer.name}</b> | <i>{post.published_at}</i>
    <p>
      {post.raw_text}
    </p>
  </li>;
}
