export let checkPagination = (data) => {
  return data.meta.pagination.pageNumber < data.meta.pagination.totalPages;
}
