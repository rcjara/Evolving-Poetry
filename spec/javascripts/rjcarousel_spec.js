describe("RJCarousel", function() {
  var carousel;

  describe("Basic Functionality", function() {
    beforeEach(function() {
      loadFixtures("carousel.html");
      carousel = $(".carousel").initRJCarousel();
      carousel.setFadeLength(0);
    });

    it("should not have a counter", function() {
      expect( $('#cara').data('rjcarousel').hasCounter() ).toEqual(false);
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

  describe("cara-counter", function() {
    beforeEach(function() {
      loadFixtures("carousel.html");
      carousel = $(".carousel").initRJCarousel({counter: true});
      carousel.setFadeLength(0);
      carousel.next();
    });

    it("should have a counter", function() {
      expect( $('#cara').data('rjcarousel').hasCounter() ).toEqual(true);
    });

    it("should have its first element marked", function() {
      expect( $('#cara-counter li').eq(0).hasClass('carousel-selected') ).toEqual(true);
    });

    it("should not have any of its other elements marked", function() {
      $('#cara-counter li').each( function(i, elem) {
        if(i != 0) {
          expect( $(elem).hasClass('carousel-selected') ).toEqual(false);
        }
      });
    });

    it("should have the right number of elements", function() {
      expect( $('#cara-counter li').size() ).toEqual(3);
      expect( $('#cara2-counter li').size() ).toEqual(4);
    });

    describe("after clicking next again", function() {
      beforeEach(function() {
        carousel.next();
      });

      it("should have its second element marked", function() {
        expect( $('#cara-counter li').eq(1).hasClass('carousel-selected') ).toEqual(true);
      });

      it("should not have any of its other elements marked", function() {
        $('#cara-counter li').each( function(i, elem) {
          if(i != 1) {
            expect( $(elem).hasClass('carousel-selected') ).toEqual(false);
          }
        });
      });
    });
  });
});

