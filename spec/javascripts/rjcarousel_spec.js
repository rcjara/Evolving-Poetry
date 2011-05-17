describe("RJCarousel", function() {
  var carousel;

  beforeEach(function() {
    loadFixtures("carousel.html");
    carousel = $(".carousel").initRJCarousel();
    carousel.setFadeLength(0);
  });

  it("should have the fixure working", function() {
    expect($('.carousel').size() ).toEqual(2);
  });

  it("should have the right number of li elements", function() {
    expect(carousel.data('rjcarousel').numElements() ).toEqual(3);
  });

  it("should have the correct div_id", function() {
    expect(carousel.data('rjcarousel').divId() ).toEqual("cara");
  });

  it("should have no elements visible on page load", function () {
    expect( $('#cara li:visible').size() ).toEqual(0);
  });

  it("should have 3 invisible elements",  function() {
    expect( $('#cara li:hidden').size() ).toEqual(3);
  });

  describe("after clicking next once", function() {
    beforeEach(function() {
      carousel.next();
    });

    it("should have one visible element", function() {
      expect($('#cara li:visible').size() ).toEqual(1);
    });

    it("should have two hidden elements", function() {
      expect($('#cara li:hidden').size() ).toEqual(2);
    });
  });

  describe("after clicking prev twice", function() {
    beforeEach(function() {
      carousel.prev();
      carousel.prev();
    });

    it("should have one visible element", function() {
      expect($('#cara li:visible').size() ).toEqual(1);
    });

    it("should have two hidden elements", function() {
      expect($('#cara li:hidden').size() ).toEqual(2);
    });
  });

  describe("two carousel elements at once", function() {
    beforeEach(function() {
      carousel.next();
    });

    it("should have seven li elements between them", function() {
      expect($('.carousel li').size() ).toEqual(7);
    });

    it("should only have two visible li elements between them", function() {
      expect($('.carousel li:visible').size() ).toEqual(2);
    });
  });
});

